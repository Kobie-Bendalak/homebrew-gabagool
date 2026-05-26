class Gabagool < Formula
  desc "Local-first AI development control plane — governs intent, context, and multi-agent workflows"
  homepage "https://github.com/Kobie-Bendalak/Gabagool"
  url "https://github.com/Kobie-Bendalak/Gabagool/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "ba7cc8acf0df5cce8512a4d83a57061d1514dca66b7fd4c5b8d614dee3dcdcd2"
  license "MIT"
  head "https://github.com/Kobie-Bendalak/Gabagool.git", branch: "main"

  depends_on "go" => :build
  depends_on "python@3.12"
  depends_on "redis"

  def install
    # Build Go services
    ENV["CGO_ENABLED"] = "0"
    cd "gateway-go" do
      system "go", "build", *std_go_args(output: libexec/"bin/gabagool-gateway"), "."
    end
    cd "failover" do
      system "go", "build", *std_go_args(output: libexec/"bin/gabagool-failover"), "."
    end

    # Stage Python context engine into libexec, install with pip
    libexec.install "context"
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", libexec/"venv"
    system libexec/"venv/bin/pip", "install", "--quiet", libexec/"context"

    # docker-compose + policies + configs (used by `gabagool up`)
    libexec.install "docker-compose.yml", "Makefile"
    libexec.install ".gabagool" if File.exist?(".gabagool")

    # Wrapper CLI on PATH
    (bin/"gabagool").write <<~SH
      #!/bin/bash
      export GABAGOOL_HOME="#{libexec}"
      export PATH="#{libexec}/bin:#{libexec}/venv/bin:$PATH"
      exec "#{libexec}/bin/gabagool-gateway" "$@"
    SH
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
