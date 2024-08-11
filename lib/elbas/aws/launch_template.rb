module Elbas
  module AWS
    class LaunchTemplate < Base
      attr_reader :id, :name, :version

      def initialize(id, name, version)
        @id = id
        @name = name
        @version = version
      end

      def update(ami)
        latest = aws_client.create_launch_template_version({
          launch_template_data: { image_id: ami.id },
          launch_template_id: self.id,
          source_version: self.version
        }).launch_template_version

        new_version = self.class.new(
          latest&.launch_template_id,
          latest&.launch_template_name,
          latest&.version_number
        )

        new_version.set_as_default

        new_version
      end

      def set_as_default
        aws_client.modify_launch_template({
          default_version: version.to_s,
          launch_template_id: id
        })
      end

      private

      def aws_namespace
        ::Aws::EC2
      end
    end
  end
end