shared_examples_for 'apiError' do |status, code, error|
  if error.present?
    Then { response.status == status }
    And { response_json['code'] == code }
    And { response_json['error'] == error }
  else
    Then { response.status == status }
    And { response_json['code'] == code }
  end
end
