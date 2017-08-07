task :find_unused_images do
  images = Dir.glob('app/assets/images/**/*')

  images_to_delete = []
  images.each do |image|
    begin
      unless File.directory?(image)
        # print "\nChecking #{image}..."
        print "."
        result = `ack -g -i '(app|public)' | ack -x -w #{File.basename(image)}`
        if result.empty?
          images_to_delete << image
        else
        end
      end
    rescue
      raise "please install ack, install on MacOSX: 'brew install ack'"
    end
  end
  puts "\n\nDelete unused files running the command below:"
  puts "rm #{images_to_delete.join(" \n")}"
end
