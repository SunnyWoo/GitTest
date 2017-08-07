# == Schema Information
#
# Table name: impositions
#
#  id                       :integer          not null, primary key
#  model_id                 :integer
#  paper_width              :float
#  paper_height             :float
#  definition               :json
#  created_at               :datetime
#  updated_at               :datetime
#  sample                   :string(255)
#  rotate                   :integer
#  type                     :string(255)
#  template                 :string(255)
#  demo                     :boolean          default(FALSE), not null
#  file                     :string(255)
#  flip                     :boolean          default(FALSE)
#  flop                     :boolean          default(FALSE)
#  include_order_no_barcode :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe Imposition, type: :model do
  let(:imposition) { Imposition::Asgard.new }

  describe '#predrill_points' do
    it 'creates empty list on new' do
      expect(imposition.predrill_points).to eq([])
    end

    it 'can be assigned and store to database correctly' do
      imposition.update(predrill_points: [{ x: 10, y: 20 }, { x: 30, y: 40 }])
      expect(imposition.predrill_points[0].x).to eq(10)
      expect(imposition.predrill_points[0].y).to eq(20)
      expect(imposition.predrill_points[1].x).to eq(30)
      expect(imposition.predrill_points[1].y).to eq(40)
    end
  end

  describe '#positions' do
    it 'creates empty list on new' do
      expect(imposition.positions).to eq([])
    end

    it 'can be assigned and store to database correctly' do
      imposition.update(positions: [{ x: 10, y: 20 }, { x: 30, y: 40 }])
      expect(imposition.positions[0].x).to eq(10)
      expect(imposition.positions[0].y).to eq(20)
      expect(imposition.positions[1].x).to eq(30)
      expect(imposition.positions[1].y).to eq(40)
    end
  end
end
