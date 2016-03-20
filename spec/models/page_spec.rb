require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:page) { create :page }

  context "validates" do
    it { expect(page).not_to be_invalid }
  end
end
