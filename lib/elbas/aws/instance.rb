module Elbas
  module AWS
    class Instance < Base
      STATE_RUNNING = 16.freeze

      attr_reader :aws_counterpart, :id, :state

      def initialize(id, options)
        @id = id
        @public_dns = options[:public_dns]
        @private_dns = options[:private_dns]
        @public_ip = options[:public_ip]
        @private_ip = options[:private_ip]
        @state = options[:state]
        @aws_counterpart = aws_namespace::Instance.new id, client: aws_client
      end

      def hostname
        case hostname_type
        when :private_dns
          @private_dns
        when :public_ip
          @public_ip
        when :private_ip
          @private_ip
        else
          @public_dns
        end
      end

      def running?
        state == STATE_RUNNING
      end

      private

      def aws_namespace
        ::Aws::EC2
      end

      def hostname_type
        fetch(:hostname_type, :public_dns)
      end
    end
  end
end
