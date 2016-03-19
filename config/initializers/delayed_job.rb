Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_jobs.log'))
Delayed::Worker.default_queue_name = 'default'
