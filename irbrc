#!/usr/bin/ruby

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:LOAD_MODULES] += ['irb/completion', 'irb/ext/save-history']

IRB.conf[:PROMPT_MODE] = :SIMPLE

# load gems
# %w[rubygems awesome_print].each do |gem|
%w[rubygems].each do |gem|
  begin
    require gem
  rescue LoadError
    puts "error loading gem #{gem}"
  end
end

# colorize output
# IRB::Irb.class_eval do
#   def output_value
#     ap @context.last_value, :multiline => false
#   end
# end


class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
  # clipboard
  def copy(str)
    IO.popen('xclip -i', 'w') { |f| f << str.to_s }
  end
  def paste
    `xclip -o`
  end
end
# sql query loging
# if defined? Rails
#   require 'logger'
#   ActiveRecord::Base.logger = Logger.new(STDOUT)
#   # somehow ar 2.3.5 on my laptop didn't catch up logger but on desktop all is ok ...
#   ActiveRecord::Base.connection.instance_eval {@logger = ActiveRecord::Base.logger}
# end
def log_to(stream)
  ActiveRecord::Base.logger = Logger.new(stream)
  # somehow ar 2.3.5 on my laptop didn't catch up logger but on desktop all is ok ...
  ActiveRecord::Base.connection.instance_eval {@logger = ActiveRecord::Base.logger}
  # ActiveRecord::Base.logger = Logger.new(stream)
  # ActiveRecord::Base.clear_active_connections!
end

def show_log
  log_to(STDOUT)
end

def hide_log
  log_to(nil)
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end
Readline.vi_editing_mode
# load File.dirname(__FILE__) + '/.railsrc' if ($0 == 'irb' && ENV['RAILS_ENV']) || ($0 == 'script/rails' && Rails.env)
class Method; def s; sl = source_location; `head -n #{sl.last} '#{sl.first}' | tail -1`.chomp; end; end
# e = ERB.new "ok #{1 + 1} ok"
# s e, :result #=> "def result(b=TOPLEVEL_BINDING)"
def s(o, n); o.method(n).s.strip; end
def vs(o, n); sl = o.method(n).source_location; system %Q(tmux send-keys -t :1.1 ':tabnew #{sl.first}' C-m "#{sl.last}G"); end
