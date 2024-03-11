require 'starhub/client'

module Starhub
  class Api
    include SharedRepoApis
    include ModelApis
    include DatasetApis

    def initialize
      @client = Starhub::Client.instance
    end

    def create_user(name, nickname, email)
      options = {
        username: name,
        name: nickname,
        email: email
      }
      @client.post("/users", options)
    end

    def update_user(name, nickname, email)
      options = {
        username: name,
        name: nickname,
        email: email
      }
      @client.put("/users/#{name}", options)
    end

    def generate_git_token(username, name, options = {})
      options[:name] = name
      res = @client.post("/user/#{username}/tokens", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def delete_git_token(username, token_name)
      @client.delete("/user/#{username}/tokens/#{token_name}")
    end

    def get_user_models(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/models", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_org_models(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/models", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_user_datasets(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/datasets", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_org_datasets(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/datasets", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def preview_datasets_parquet_file(username, dataset_name, path, options = {})
      options[:count] ||= 6
      res = @client.get("/datasets/#{username}/#{dataset_name}/viewer/#{path}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def create_ssh_key(username, key_name, content)
      options = {
        username: username,
        name: key_name,
        content: content
      }
      @client.post("/user/#{username}/ssh_keys", options)
    end

    def delete_ssh_key(username, key_name)
      options = {
        username: username,
        name: key_name
      }
      @client.delete("/user/#{username}/ssh_key/#{key_name}")
    end

    def create_organization(username, org_name, org_full_name, desc)
      options = {
        username: username,
        name: org_name,
        full_name: org_full_name,
        description: desc
      }
      @client.post("/organizations", options)
    end

    def update_organization(username, org_name, org_full_name, desc)
      options = {
        current_user: username,
        name: org_name,
        full_name: org_full_name,
        description: desc
      }
      @client.put("/organizations/#{org_name}", options)
    end

    def text_secure_check(scenario, content)
      return unless sensitive_check_enabled?
      return if content.blank?
      options = {
        scenario: scenario,
        text: content
      }
      res = @client.post("/sensitive/text", options)
      if res.status == 400
        raise SensitiveContentError, '监测到敏感内容'
      elsif res.status == 500
        raise StarhubError, "Git服务器报错"
      else
        res
      end
    end

    def image_secure_check(scenario, oss_bucket_name, oss_object_name)
      return unless sensitive_check_enabled?
      return if oss_object_name.blank?
      options = {
        scenario: scenario,
        oss_bucket_name: oss_bucket_name,
        oss_object_name: oss_object_name
      }
      res = @client.post("/sensitive/image", options)
      if res.status == 400
        raise SensitiveContentError, '监测到敏感内容'
      elsif res.status == 500
        raise StarhubError, "Git服务器报错"
      else
        res
      end
    end

    def create_membership(org_name, op_user, role, user)
      options = {
        op_user: op_user,
        role: role,
        user: user
      }
      @client.post("/organizations/#{org_name}/members", options)
    end

    def delete_membership(org_name, op_user, role, user)
      options = {
        op_user: op_user,
        role: role
      }
      @client.delete("/organizations/#{org_name}/members/#{user}", options)
    end

    # TODO: add more starhub api

    private

    def sensitive_check_enabled?
      config_from_env = ENV.fetch('SENSITIVE_CHECK', nil)
      system_config = SystemConfig.first
      feature_flags = (system_config.feature_flags rescue {}) || {}
      sensitive_check = config_from_env || feature_flags['sensitive_check']
      sensitive_check.to_s == 'true'
    end
  end
end
