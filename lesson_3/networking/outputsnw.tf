output "aws_vpc" {
  value = aws_vpc.jeks.id
}
output "aws_subnet" {
  value = aws_subnet.pub1.*.id
}