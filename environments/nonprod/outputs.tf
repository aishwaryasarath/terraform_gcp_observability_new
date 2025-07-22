output "redis_instance_ids" {
  value = {
    for region_key, m in module.redis_instance :
    region_key => m.id
  }
}
