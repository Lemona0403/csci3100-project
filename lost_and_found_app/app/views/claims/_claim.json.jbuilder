json.extract! claim, :id, :status, :contact_info, :message, :created_at, :updated_at
json.url claim_url(claim, format: :json)
