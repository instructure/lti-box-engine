require 'spec_helper'

describe 'Workflow', type: :request, js: true do
  it 'app should be accessible via POST' do
    visit '/lti_box_engine/test/backdoor'
    click_button('Submit')
    expect(page).to have_content 'The OAuth signature was invalid'
  end
end
