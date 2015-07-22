module Flatcar
  class Runner

    attr_reader :args, :name

    def initialize(args)
      @args = args
    end


    def execute
      command = args.shift

      case command
      when 'new'
        @name = args.shift || 'we_have_app'
        options = args
        puts 'before exec rails new'
        `rails #{command} #{name} -B #{options.join(' ')}`
        puts 'after exec rails'
        create_from_template('Dockerfile.erb', 'Dockerfile')
        `cd #{name} && docker build -t #{name} .`
      when 'run'
        exec "docker run -it -v #{Dir.pwd}:/var/app -w /var/app -p 3000:3000 centurylink/flatcar-base rails s"
      else
        puts "Error: Command '#{command}' not recognized"
      end
    end

    private

    def templates
      File.join File.expand_path('..',  File.dirname(__dir__)), 'templates'
    end

    def create_from_template(template_name, output_file)
      template = ERB.new(File.read("#{templates}/#{template_name}"), nil, '-')
      result = template.result(binding)
      puts "MAKIN THAT DOCKERFILE!"
      File.open("#{name}/#{output_file}", 'w') { |file| file.write(result) }
    end

  end
end
