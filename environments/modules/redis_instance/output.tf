output "instance_id" {
  value       = google_redis_instance.redis_instance.id
  description = "Redis instance ID"
}

output "id" {
  value = google_redis_instance.redis_instance.id
}

output "redis_instance_name" {
  value = google_redis_instance.redis_instance.name
}

output "redis_instance_host" {
  value = google_redis_instance.redis_instance.host

}

