[English Version](./setup_en.md)

### 通用环境变量
- **RAILS_MASTER_KEY** \
  用于解密 Rails Credentials，当前开源项目的 master key 为：`64f15f995b044427e43fe4897370fd66`

- **ON_PREMISE** \
  一个用于切换项目版本的开关，如果为 true 则是 on premise 版本，否则是非 on premise 版本。目前的主要差别在于，非 on premise 的版本支持的登录方式为 OIDC 的登录授权方式。on premise 版本的登录方式为系统自带的登录授权。

- **SENSITIVE_CHECK** \
  一个用于打开和关闭敏感信息监测的开关，如果为 true 表示打开了敏感信息监测。这个需要同 Starhub Server 协作使用，如果 Starhub Server 开通了支持敏感信息监测的 API 那么我们就可以打开这个开关。

- **SUPER_USERS** \
  你可以通过这个环境变量设置系统的超级管理员用户，设置的方式为逗号分隔的电话号码。这也意味着，在注册的时候需要填写匹配的电话号码。

### System Config(系统配置)
这个是一种进行项目配置的方式，基于一个数据对象 SystemConfig，对应到数据库表 system_configs。针对每个环境使用管理员账号只需要新建一条 SystemConfig 记录。

目前系统支持这些 System Config 字段，他们都是 jsonb 的类型：
- general_configs
- oidc_configs
- starhub_configs
- license_configs
- feature_flags
- s3_configs

当前你可以随时添加更多其他的字段

### 项目依赖
在启动项目之前，请先确保所有的依赖都完成设置

##### 对象存储
项目集成了 S3 的标准接口，可以通过下面的方式进行配置：

  - 环境变量
  - Rails Credentials
  - System Config

支持如下字段(环境变量需大写)：

  - bucket_name
  - endpoint
  - access_id
  - access_secret
  - region

##### Starhub Server
当前项目是 Starhub Client，我们模型数据集等功能都依赖于 Starhub Server 提供的服务。我们可以通过下面的方式进行配置：

  - 环境变量
  - Rails Credentials
  - System Config

支持的字段如下：

  - 环境变量：STARHUB_BASE_URL, STARHUB_TOKEN
  - Credentials/SystemConfig: base_url, token

##### OIDC
如果使用是非 on premise 的版本，即 ON_PREMISE 为 false，那么系统支持的登录授权方式为 OIDC 的方式，可以通过下面的方式进行配置：

  - 环境变量
  - Rails Credentials
  - System Config

环境变量支持的字段如下：

  - OIDC_IDENTIFIER
  - OIDC_SECRET
  - OIDC_REDIRECT_URI
  - OIDC_AUTHORIZATION_ENDPOINT
  - OIDC_TOKEN_ENDPOINT
  - OIDC_USERINFO_ENDPOINT

其他两种方式支持的字段如下：

  - identifier
  - secret
  - redirect_uri
  - authorization_endpoint
  - token_endpoint
  - userinfo_endpoint


### 项目启动步骤

1. 克隆项目代码

```
git clone <项目代码仓库地址>
cd <项目目录>
```

2. 安装依赖

确保你已经安装了Ruby（推荐版本 3.1 或更高）和Node.js（推荐版本 16.0 或更高）。

```
bundle install
yarn install
```

这将安装项目所需的 Ruby 和 JavaScript 依赖项。

3. 配置数据库

```
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

这将创建并迁移数据库以及初始化数据，确保你的数据库配置正确。

4. 启动开发服务器

```
bin/dev
```

这将启动 Rails 开发服务器以及 tailwind css 编译，并监听默认的本地开发端口（通常可用 http://localhost:3000 来访问）。


### 系统初始化默认用户

系统会默认创建一个超级用户 `admin001`，密码默认为 `admin001`，可以通过 `http://localhost:3000/admin` 进入后台进行系统配置和管理。
