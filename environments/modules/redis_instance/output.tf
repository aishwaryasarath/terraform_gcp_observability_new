output "instance_id" {
  value       = google_redis_instance.redis_instance.id
  description = "Redis instance ID"
}

output "id" {
  value = google_redis_instance.redis_instance.id
}
