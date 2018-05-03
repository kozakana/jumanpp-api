app_root = File.expand_path '../', __FILE__

worker_processes 1
working_directory app_root
timeout 30

listen 4567

pid File.expand_path '../pids/unicorn.pid', __FILE__
