require "active_model"

module Rumination
  class DevUser
    CannotBeInitialized = Class.new(RuntimeError)
    include ActiveModel::Model
    attr_accessor :name, :host, :password, :email

    def initialize args={}
      super
      self.name ||= ENV["USER"]
      raise CannotBeInitialized, "Can't guess dev user name" unless self.name.present?
      self.password ||= ENV["DEV_PASSWORD"]
      raise CannotBeInitialized, "Can't guess dev user password" unless self.password.present?
      self.host ||= ENV["DEV_HOST"]
      raise CannotBeInitialized, "Can't guess dev user email" unless self.email.present? || self.host.present?
      self.email ||= [name, host].join("@")
    end
  end
end
