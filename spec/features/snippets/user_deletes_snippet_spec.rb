# frozen_string_literal: true

require 'rails_helper'

describe 'User deletes snippet' do
  let(:user) { create(:user) }
  let(:content) { 'puts "test"' }
  let(:snippet) { create(:personal_snippet, :public, content: content, author: user) }

  before do
    sign_in(user)

    visit snippet_path(snippet)
  end

  it 'deletes the snippet' do
    first(:link, 'Delete').click

    expect(page).not_to have_content(snippet.title)
  end
end
