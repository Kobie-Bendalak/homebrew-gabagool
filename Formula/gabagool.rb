# typed: false
# frozen_string_literal: true

class Gabagool < Formula
  desc "Local-first AI development proxy and context engine"
  homepage "https://github.com/Kobie-Bendalak/Gabagool"
  version "3.1.7"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Kobie-Bendalak/gabagool-dist/releases/download/v3.1.7/gabagool_3.1.7_darwin_arm64.tar.gz"
      sha256 "a14c2a0f7fb14a57db6bc2846e90de72de9576d089c7d371884a676d7aade2cf"

      def install
        bin.install "gabagool"
        generate_completions_from_executable(bin/"gabagool", "completion")
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/Kobie-Bendalak/gabagool-dist/releases/download/v3.1.7/gabagool_3.1.7_darwin_x86_64.tar.gz"
      sha256 "9e4e5359bf0260203bc4643baaa82d6fd5bac8ccc0fa8032504cd0685f725f7c"

      def install
        bin.install "gabagool"
        generate_completions_from_executable(bin/"gabagool", "completion")
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/Kobie-Bendalak/gabagool-dist/releases/download/v3.1.7/gabagool_3.1.7_linux_arm64.tar.gz"
      sha256 "e1afcd9c28fa3b426f8d76e87c3f71f1f6e49f9eef1fd7c359730d214ec5cf8e"

      def install
        bin.install "gabagool"
        generate_completions_from_executable(bin/"gabagool", "completion")
      end
    end
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/Kobie-Bendalak/gabagool-dist/releases/download/v3.1.7/gabagool_3.1.7_linux_x86_64.tar.gz"
      sha256 "332bfc7c483797226ca2ac9894c62f0dfb65afdb210fd753ca458b2872190037"

      def install
        bin.install "gabagool"
        generate_completions_from_executable(bin/"gabagool", "completion")
      end
    end
  end

  def caveats
    <<~EOS
      Gabagool needs Docker Desktop (or another docker-compose-capable daemon)
      running to start its services.

      First run:
        gabagool init       # detects Keychain OAuth, writes ~/.gabagool/env, pulls images
        gabagool start      # bring the stack up
        gabagool doctor     # verify everything is wired

      Auto-start at login (optional):
        gabagool service install

      Point your IDE at the proxy:
        export ANTHROPIC_BASE_URL=http://localhost:7878
    EOS
  end

  test do
    system bin/"gabagool", "--help"
  end
end
