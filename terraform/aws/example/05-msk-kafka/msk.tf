resource "aws_msk_cluster" "eos-kafka01" {
  cluster_name           = "eos-kafka01"
  kafka_version          = "3.8.x"
  number_of_broker_nodes = 2
  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = ["subnet-012c74198ecc303e8", "subnet-0f35e939a90a45918"]
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
    security_groups = ["sg-01dc33cd3198b94bd"]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = false
    }
  }
  client_authentication {
    unauthenticated = true
  }
}