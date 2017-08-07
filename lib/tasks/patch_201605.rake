namespace :patch_201605 do
  task fix_provinces: :environment do
    special_mapping = {
      '广西壮族' => '广西省',
      '宁夏回族' => '宁夏',
      '新疆维吾尔' => '新疆'
    }
    data = YAML.load_file(Rails.root.join('config', 'china_city_codes.yml'))
    data.each do |province_data|
      name = province_data['name'].gsub('自治区', '')
      name = special_mapping[name] || name
      province = Province.find_by_name(name)
      if province
        province.code = province_data['code']
        province.save
      else
        puts "#{name} not found"
      end
    end
  end
end
