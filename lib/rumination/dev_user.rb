require "active_model"

module Rumination
  class DevUser
    include ActiveModel::Model

    CannotBeInitialized = Class.new(RuntimeError)
    attr_accessor :name, :host, :password, :email

    def initialize args={}
      super
      self.name ||= ENV["USER"]
      self.name ||= self.email[/^.*(?=@)/] if self.email.present?
      raise CannotBeInitialized, "Can't guess dev user name" unless self.name.present?
      self.password ||= ENV["DEV_PASSWORD"]
      raise CannotBeInitialized, "Can't guess dev user password" unless self.password.present?
      self.host ||= ENV["DEV_HOST"]
      raise CannotBeInitialized, "Can't guess dev user email" unless self.email.present? || self.host.present?
      self.email ||= [name, host].join("@")
    end

    def attributes
      attribute_names.map{|attribute| [attribute, send(attribute)]}.to_h
    end

    def attribute_names
      %w[name password host email]
    end
  end
end
