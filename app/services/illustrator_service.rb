require 'open3'
require 'timeout'

class IllustratorService
  def running?
    run_apple_script('ai_detector.as').chomp == 'true'
  end

  def launch
    run_apple_script('ai_launcher.as')
  end

  def quit
    run_apple_script('ai_killer.as')
  end

  # 處理一百次就重開, 雖然 adobe 建議可達一千次...
  def activate
    if current_count == 100
      reset_counter
      quit
    end
    touch
    launch
  end

  def run_apple_script(file, *arguments)
    path = Rails.root + 'app/services/illustrator_service/apple_scripts' + file
    Open3.popen3('osascript', '-e', File.read(path), *arguments.map(&:to_s)) do |_stdin, stdout, stderr, _wait_thr|
      error_message = stderr.gets
      if error_message.present?
        fail IllustratorError, error_message if file == 'ai_killer.as'
        run_apple_script('ai_killer.as')
        fail IllustratorError, error_message
      end
      stdout.gets
    end
  end

  # Scripts that create, save, and close many Illustrator files should
  # periodically quit and relaunch Illustrator. The recommended maximum number
  # of files to process before quitting and relaunching Illustrator is:
  # Windows: 500 files
  # Mac OS: 1000 files
  def current_count
    if File.exist?(counter_file)
      File.read(counter_file).to_i
    else
      0
    end
  end

  def touch
    next_value = current_count + 1
    File.open(counter_file, 'w') { |f| f.write(next_value) }
  end

  def counter_file
    '/tmp/ai-counter.txt'
  end

  def reset_counter
    File.delete(counter_file) if File.exist?(counter_file)
  end

  def run_javascript(file, *arguments)
    Timeout.timeout(600) do
      Rails.logger.debug "Run Illustrator Javascript: #{file} with arguments #{arguments.join(' ')}"
      run_apple_script('ai_js_runner.as', to_javascript_full_path(file).to_s, *arguments)
    end
  rescue Timeout::Error
    quit
  end

  def load_javascript(file)
    Rails.logger.debug "Load Illustrator Javascript: #{file}"
    run_apple_script('ai_js_loader.as', to_javascript_full_path(file).to_s)
  end

  def to_javascript_full_path(file)
    Rails.root + 'app/services/illustrator_service/javascripts' + file
  end

  def ai_to_png(ai_path, png_path)
    activate
    run_javascript('ai_to_png.js', ai_path, png_path)
  end

  def build_demo_work_for_ai(work)
    args = DemoWorkArgumentsGenerator.new(work)
    activate
    load_javascript('json2.js')
    run_javascript('work_builder.js', args.generate.to_json)
    work.update!(ai: args.ai, pdf: args.pdf)
  ensure
    args.close
  end

  # print_item, template_path, image_path, qrcode_path, output_path, labels
  def build_vanaheim_imposition(*args)
    generator = VanaheimImpositionArgumentsGenerator.new(*args)
    activate
    load_javascript('json2.js')
    run_javascript('vanaheim_builder.js', generator.generate.to_json)
  end

  # print_items, template_path, qrcode_path, output_path, labels
  def build_alfheim_imposition(arguments)
    activate

    Rails.logger.info('#build_alfheim_imposition: ')
    Rails.logger.info(arguments)

    load_javascript('json2.js')
    run_javascript('alfheim_builder.js', arguments.to_json)
  end
end
