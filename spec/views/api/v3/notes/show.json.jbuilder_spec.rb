require 'spec_helper'

RSpec.describe 'api/v3/notes/show.json.jbuilder', :caching, type: :view do
  let(:note) { create(:note) }

  it 'renders note' do
    allow(controller).to receive(:current_admin)
    assign(:note, note)
    render
    expect(JSON.parse(rendered)).to eq(
      'note' => {
        'id' => note.id,
        'message' => note.message,
        'created_at' => note.created_at.as_json,
        'user_email' => note.user_email
      }
    )
  end

  it 'renders with admin' do
    allow(controller).to receive(:current_admin).and_return(note.user)
    assign(:note, note)
    render
    expect(JSON.parse(rendered)).to eq(
      'note' => {
        'id' => note.id,
        'message' => note.message,
        'created_at' => note.created_at.as_json,
        'user_email' => note.user_email,
        'links' => {
          'update' => view.polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
        }
      }
    )
  end
end
