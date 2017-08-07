class UniqueTimestampDate < ActiveRecord::Migration
  def change
    duplicate_date = Timestamp.all.each_with_object(Hash.new { 0 }) do |timestamp, hash|
      hash[timestamp.date.to_s] += 1
    end.delete_if { |_key, value| value == 1 }

    duplicate_date.each do |key, _value|
      Timestamp.where(date: Date.parse(key)).each_with_index do |timestamp, index|
        next if index == 0 # 因为 today.lock(true).first
        timestamp.delete
      end
    end

    remove_index :timestamps, :date
    add_index :timestamps, :date, unique: true
  end
end
