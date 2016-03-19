require 'rails_helper'

RSpec.describe PageLink, type: :model do
  let(:current_link) { create :page_link }

  it { expect(current_link.name).to eq("hello")}
end
