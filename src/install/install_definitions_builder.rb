require "./src/install/install_definitions/on_host_instrumentation_builder"
require "./src/install/install_definitions/service_builder"
require "./src/install/install_definitions/service_instrumentation_builder"

module Install
  class InstallDefinitionsBuilder

      def initialize(context, provisioned_resources)
        @context = context
        @provisioned_resources = provisioned_resources
        @install_definitions = []
      end

      def build()
        return @install_definitions.flatten()
      end

      def with_onhost_instrumentations()
        builder = Install::InstallDefinitions::OnHostInstrumentationBuilder.new(@context, @provisioned_resources)
        definitions = builder.build()
        @install_definitions.push(definitions)
        return self
      end

      def with_services()
        builder = Install::InstallDefinitions::ServiceBuilder.new(@context, @provisioned_resources)
        definitions = builder.build()
        @install_definitions.push(definitions)
        return self
      end

      def with_service_instrumentations()
        builder = Install::InstallDefinitions::ServiceInstrumentationBuilder.new(@context, @provisioned_resources)
        definitions = builder.build()
        @install_definitions.push(definitions)
        return self
      end

  end
end