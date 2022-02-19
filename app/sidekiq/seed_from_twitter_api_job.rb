# uasge: SeedFromTwitterApiJob.perform_async
# SeedFromTwitterApiJob.perform_async('#twitterparswer', 50)
#SeedFromTwitterApiJob.perform_in(5.minutes, 'bob', 5)
#SeedFromTwitterApiJob.perform_at(5.minutes.from_now, 'bob', 
# docs: https://github.com/mperham/sidekiq/wiki/Getting-Started

# class SeedFromTwitterApiJob
#   include Sidekiq::Job

# #  def perform(*args)
#   def perform(search_string, api_call_count, opts={})
#       # Do something
#     puts "Ciao a tutti da sideqik. You called perform(search_string=#{search_string}, api_call_count=#{api_call_count}, opts=#{opts})"
#     #`touch Sidekiq.perform_running.DELETEME`
#     puts "Damn. Requires REDIS. ABORT for now."
#   end
# end
