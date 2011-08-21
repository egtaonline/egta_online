mongo: sudo mongod --journal
redis: sudo redis-server
profile_actions_worker: rake environment resque:work QUEUE=profile_actions
nyx_actions_worker: rake environment resque:work QUEUE=nyx_actions