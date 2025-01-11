
defmodule PhxLivePoller.Accounts.UserError do
  defexception [:reason, :status]

  def message(exception) do
    case exception.reason do
      :empty_data -> "User name and email should not be empty"
      :exists    -> "User: #{exception.status} already exists"
      :bad_email -> "Bad user email value: #{exception.status}"
      _ -> "User could not be added at this time"  
    end  
  end  
end  
