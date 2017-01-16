module FayeExtensions
  Config = Struct.new(:hash_algorithm, :token_life, :secret, :broadcast_url, :log_level, :log_targets)
end