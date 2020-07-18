class TransferService
  def initialize(from_user_id, to_user_id, amount)
    @from_user_id = from_user_id
    @to_user_id = to_user_id
    @amount = amount
  end

  def call
    User.transaction do
      verify_available_balance
      transfer
    end
  end

  def self.call(*args)
    new(*args).call
  end

  private
  attr_reader :from_user_id, :to_user_id, :amount

  def from_user
    @from_user ||= User.find(from_user_id).lock!
  end

  def to_user
    @to_user ||= User.find(to_user_id).lock!
  end

  def verify_available_balance
    return if from_user.balance >= amount

    raise NotEnoughBalance, 'Not enough balance'
  end

  def transfer
    from_user.balance -= amount
    from_user.save!
    to_user.balance += amount
    to_user.save!
  end
end
