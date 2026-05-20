output "public_ip" {

  value = aws_instance.lake.public_ip

}

output "ssh" {

  value = "ssh ubuntu@${aws_instance.lake.public_ip}"

}