# frozen_string_literal: true

class OperationConfirmationService
  def initialize(user_id:, operation_id:, write_off:)
    @user = User[user_id]
    @operation = Operation[operation_id]
    @write_off = write_off.to_f
  end

  def call
    raise 'Operation not found' unless @operation
    raise 'Invalid user' unless @user && @operation.user_id == @user.id

    actual_write_off = [@write_off, @operation.allowed_write_off.to_f].min
    check_summ = @operation.check_summ.to_f - actual_write_off

    @operation.update(
      write_off: actual_write_off,
      check_summ: check_summ,
      done: true
    )

    {
      status: 'ok',
      message: 'Операция подтверждена',
      operation: {
        user_id: @user.id,
        earned_bonus: @operation.cashback.to_f.round(2),
        total_cashback_percent: @operation.cashback_percent.to_f.round(2),
        total_discount: @operation.discount.to_f.round(2),
        total_discount_percent: @operation.discount_percent.to_f.round(2),
        bonus_written_off: actual_write_off.round(2),
        final_amount: check_summ.round(2)
      }
    }
  end
end
