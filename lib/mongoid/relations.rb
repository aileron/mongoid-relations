require "mongoid/relations/version"

module Mongoid
  module Relations
    class Const
      @@instances = {}
      @@instances_= {}

      def id
        @@instances_[ self ]
      end

      def self.set name, &block
        i = new &block
        @@instances_[ i ] = name
        @@instances[ name ] = i
      end

      def self.find id
        @@instances[ id ]
      end
    end

    extend ActiveSupport::Concern
    module ClassMethods
      def belongs_to_sibling name,opt
        field "#{name}_id"
        field_name = name.pluralize

        define_method "#{name}=" do |obj|
          send("#{name_id}=",obj.id)
        end

        define_method name do
          _id = send("#{name}_id")
          _root.send( field_name ).find _id
        end
      end

      def belongs_to_const name,class_name: nil
        field "#{name}_id"
        type = (class_name || name.capitalize).constantize

        raise '#{type} is not Mongoid::Relations::Const extended!' unless type.ancestors.include?(Mongoid::Relations::Const)

        define_method "#{name}=" do |obj|
          send("#{name}_id=",obj.id )
        end

        define_method name do
          _id = send("#{name}_id")
          type.find _id
        end
      end
    end
  end
end
