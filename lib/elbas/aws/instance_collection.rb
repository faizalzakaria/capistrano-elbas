module Elbas
  module AWS
    class InstanceCollection < Base
      include Enumerable

      attr_reader :instances

      def initialize(ids)
        @ids = ids
        @instances = query_instances_by_ids(ids).map do |i|
          Instance.new(
            i.instance_id,
            public_dns: i.public_dns_name,
            private_dns: i.private_dns_name,
            public_ip: i.public_ip_address,
            private_ip: i.private_ip_address,
            state: i.state.code
          )
        end
      end

      def running
        select(&:running?)
      end

      def each(&block)
        instances.each(&block)
      end

      private
        def aws_namespace
          ::Aws::EC2
        end

        def query_instances_by_ids(ids)
          aws_client
            .describe_instances(instance_ids: @ids)
            .reservations.flat_map(&:instances)
        end
    end
  end
end
