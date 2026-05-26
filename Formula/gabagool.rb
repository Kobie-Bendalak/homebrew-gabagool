class Gabagool < Formula
  desc "Local-first AI development control plane — governs intent, context, and multi-agent workflows"
  homepage "https://github.com/Kobie-Bendalak/Gabagool"
  url "https://github.com/Kobie-Bendalak/Gabagool/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "876059fbcd58bcfe054e499c66d9ec2e8c93eba68e787adc010bc15695f92c37"
  license "MIT"
  head "https://github.com/Kobie-Bendalak/Gabagool.git", branch: "main"

  bottle do
    root_url "https://github.com/Kobie-Bendalak/Gabagool/releases/download/v1.0.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6101e9760dc4592777540a80825cd3d09c18f8f2c45a88701a30623f2b04cf83"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "30e548e48d0cf2df66c38f348716114b9a9ef4d75044a0ceb4e222325cf6217f"
  end

  depends_on "go" => :build
  depends_on "python@3.12"
  depends_on "redis"

  def install
    # Go services — built into the bottle, relocate cleanly.
    ENV["CGO_ENABLED"] = "0"
    cd "gateway-go" do
      system "go", "build", *std_go_args(output: libexec/"bin/gabagool-gateway"), "."
    end
    cd "failover" do
      system "go", "build", *std_go_args(output: libexec/"bin/gabagool-failover"), "."
    end

    # Stage Python source + ops files (venv built in post_install).
    libexec.install "context"
    libexec.install "docker-compose.yml", "Makefile"
    libexec.install ".gabagool" if File.exist?(".gabagool")

    (bin/"gabagool").write <<~SH
      #!/bin/bash
      export GABAGOOL_HOME="#{libexec}"
      export PATH="#{libexec}/bin:#{libexec}/venv/bin:$PATH"
      exec "#{libexec}/bin/gabagool-gateway" "$@"
    SH
  end

  # Venv created here, not in `install`, so the bottle doesn't include any
  # Python wheel `.so` files. Some wheels (e.g. jiter) have insufficient
  # Mach-O header padding, which breaks `brew bottle`'s install_name_tool
  # relocation step. Building the venv post-install sidesteps the issue.
  def post_install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    system python, "-m", "venv", libexec/"venv"
    system libexec/"venv/bin/pip", "install", "--quiet", "--upgrade", "pip"
    system libexec/"venv/bin/pip", "install", "--quiet", libexec/"context"
  end

  service do
    run [opt_bin/"gabagool"]
    keep_alive true
    log_path var/"log/gabagool.log"
    error_log_path var/"log/gabagool.err.log"
  end

  test do
    assert_predicate libexec/"bin/gabagool-gateway", :exist?
    assert_predicate libexec/"bin/gabagool-failover", :exist?
    assert_predicate bin/"gabagool", :executable?
  end
end
