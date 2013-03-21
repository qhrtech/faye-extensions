module FayeExtensions
  Config = Struct.new(:hash_algorithm, :token_life, :secret, :broadcast_url)
end