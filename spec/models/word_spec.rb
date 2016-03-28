require 'rails_helper'

RSpec.describe Word, type: :model do
  before { allow_any_instance_of(Page).to receive(:find_links).and_return((["arr"])) }
  let!(:page) { create :page }

  context "validates" do
    let(:word) { create :word, page: page }
    let(:without_name) { Word.create!(definition: "", content: "1", page_id: 1) }
    let(:without_content) { Word.create!(definition: "Мир", content: "", page_id: 1) }
    let(:without_page) { Word.create!(definition: "Млечный путь", content: "галактика" ) }

    it { expect(word).to be_valid }
    it { expect{ without_name.definition }.to    raise_error(ActiveRecord::RecordInvalid, "Validation failed: Definition can't be blank") }
    it { expect{ without_content.content }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Content can't be blank") }
    it { expect{ without_page.page_id }.to    raise_error(ActiveRecord::RecordInvalid, "Validation failed: Page can't be blank") }
  end

  context "check accessory" do
    let(:word) { Word.first }
    it { expect(page.word).to eq(word)}
  end

end