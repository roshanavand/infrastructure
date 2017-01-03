require 'spec_helper'

describe 'HelloWorld Login' do
  it 'shows the login form when not logged in' do
    visit WEBSITE_URL
    expect(page).to have_content('Login')
  end

  it 'can sign up' do
    visit WEBSITE_URL
    click_on 'Sign Up'
    expect(page).to have_content('Signup!')
    fill_in 'user_name', with: 'Mos Roshanavand'
    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_password', with: '123'
    fill_in 'user_password_confirmation', with: '123'
    click_button 'Submit'
    expect(page).to have_content('Hello World!')
  end

  it 'does not sign up with incomplete form' do
    visit WEBSITE_URL
    click_on 'Sign Up'
    expect(page).to have_content('Signup!')
    fill_in 'user_name', with: 'Mos Roshanavand'
    click_button 'Submit'
    expect(page).to have_content('Signup!')
  end

  it 'can login with valid credentials' do
    visit WEBSITE_URL
    fill_in 'email', with: 'test@test.com'
    fill_in 'password', with: '123'
    click_on 'Submit'
    expect(page).to have_content('Hello World!')
  end

  it 'cannot login with invalid credentials' do
    visit WEBSITE_URL
    fill_in 'email', with: 'thisemailmustnotexist@nonexistant.fake'
    fill_in 'password', with: 'blahblah'
    click_on 'Submit'
    expect(page).to have_content('Login')
  end
end
