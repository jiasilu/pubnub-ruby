require 'pubnub'

# I should get a message on channel a once a second, but it doesnt appear so... why not?


# x.channel is nil - please fix

cb1 = lambda { |x|
  puts("cb3 says on channel #{x.channel}: msg: #{x.message}") }
cb2 = lambda { |x| puts("cb3 says on channel #{x.channel}: msg: #{x.message}") }
cb3 = lambda { |x| puts("cb3 says on channel #{x.channel}: msg: #{x.message}") }


p = Pubnub.new(:subscribe_key => "demo", :publish_key => "demo")

p.subscribe(:channel => "a", :callback => cb1, :http_sync => false)
sleep(3)
#p.subscribe(:channel => "ping_3", :callback => cb2, :http_sync => false)


# Provide example of pubnub subcribe with block here

x = 10

while (x > 0) do

  puts("sleeping...")
  sleep 1
  x=x-1

end

puts("unsubbing from a")
p.unsubscribe(:channel => "a", :callback => cb3)

x = 10

while (x > 0) do

  puts("sleeping...")
  sleep 1
  x=x-1

end


x = 10
while (x > 0) do

# provide publish example with block

end