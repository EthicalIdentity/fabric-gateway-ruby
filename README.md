# Hyperledger Fabric Gateway gRPC SDK

Hyperledger Fabric Gateway gRPC SDK generated directly from protos found at: https://github.com/hyperledger/fabric-protos.

## Development Steps

```
$ git submodule update --init --recursive
$ grpc_tools_ruby_protoc -I ./fabric-protos --ruby_out=./lib --grpc_out=./lib ./fabric-protos/gateway/gateway.proto
```
