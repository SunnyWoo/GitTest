require 'spec_helper'

RSpec.describe 'api/v3/_note.json.jbuilder', :caching, type: :view do
  let(:note) { create(:note) }

  it 'renders note' do
    render 'api/v3/note', note: note
    expect(JSON.parse(rendered)).to eq(
      'id' => note.id,
      'message' => note.message,
      'created_at' => note.created_at.as_json,
      'user_email' => note.user_email
    )
  end

  it 'renders with admin' do
    render 'api/v3/note', note: note, admin: note.user
    expect(JSON.parse(rendered)).to eq(
      'id' => note.id,
      'message' => note.message,
      'created_at' => note.created_at.as_json,
      'user_email' => note.user_email,
      'links' => {
        'update' => view.polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
      }
    )
  end
end
