require 'rails_helper'

describe TransferService do
  let(:to) { create(:user, balance: 100) }

  context 'when transfer is possible' do
    let(:from) { create(:user, balance: 300) }

    before do
      described_class.call(from.id, to.id, 200)
    end

    it 'reduces balance of the source user' do
      expect(from.reload.balance).to eq 100
    end

    it 'increases balance of the target user' do
      expect(to.reload.balance).to eq 300
    end
  end

  context 'when source user has not enough money' do
    let(:from) { create(:user, balance: 500) }

    before do
      expect do
        described_class.call(from.id, to.id, 700)
      end.to raise_error(NotEnoughBalance)
    end

    it 'does not change the balance of the source user' do
      expect(from.reload.balance).to eq 500
    end

    it 'does not change the balance of the target user' do
      expect(to.reload.balance).to eq 100
    end
  end

  context 'when source user does not exist' do
    it "does not increase target user's balance" do
      expect do
        described_class.call('from', to.id, 700)
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(to.reload.balance).to eq 100
    end
  end

  context 'when target user does not exist' do
    it "does not increase source user's balance" do
      source = create(:user, balance: 900)
      expect do
        described_class.call(source.id, 'to', 700)
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(source.reload.balance).to eq 900
    end
  end
end
