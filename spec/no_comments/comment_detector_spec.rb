# frozen_string_literal: true

require "spec_helper"
RSpec.describe NoComments::CommentDetector do
  include described_class
  describe "#magic_comment?" do
    it "returns true for magic comments" do
      expect(magic_comment?("# frozen_string_literal: true")).to be true
      expect(magic_comment?("# encoding: utf-8")).to be true
      expect(magic_comment?("# coding: utf-8")).to be true
      expect(magic_comment?("# warn_indent: true")).to be true
      expect(magic_comment?("# fileencoding: utf-8")).to be true
      expect(magic_comment?("# -*- coding: big5 -*-")).to be true
      expect(magic_comment?("# vim: set fileencoding=utf-8 :")).to be true
    end

    it "returns false for non-magic comments" do
      expect(magic_comment?("# This is a comment")).to be false
      expect(magic_comment?("#!/usr/bin/env ruby")).to be false
      expect(magic_comment?("# rubocop:disable Style/MethodLength")).to be false
    end
  end

  describe "#tool_comment?" do
    it "returns true for tool-specific comments" do
      expect(tool_comment?("# rubocop:disable Style/MethodLength")).to be true
      expect(tool_comment?("# rubocop:enable Style/MethodLength")).to be true
      expect(tool_comment?("# reek:TooManyStatements { max_statements: 6 }")).to be true
      expect(tool_comment?("# simplecov: start")).to be true
      expect(tool_comment?("# coveralls: off")).to be true
      expect(tool_comment?("# pry")).to be true
      expect(tool_comment?("# byebug")).to be true
      expect(tool_comment?("# noinspection RubyResolve")).to be true
      expect(tool_comment?("# sorbet: true")).to be true
      expect(tool_comment?("# type: strict")).to be true
    end

    it "returns false for non-tool-specific comments" do
      expect(tool_comment?("# This is a comment")).to be false
      expect(tool_comment?("# frozen_string_literal: true")).to be false
      expect(tool_comment?("#!/usr/bin/env ruby")).to be false
    end
  end

  describe "#documentation_comment?" do
    it "returns true for documentation comments" do
      expect(documentation_comment?("# @param name [String]")).to be true
      expect(documentation_comment?("# @return [Integer]")).to be true
    end

    it "returns false for non-documentation comments" do
      expect(documentation_comment?("# Just a comment")).to be false
      expect(documentation_comment?("# rubocop:disable all")).to be false
    end
  end
end
