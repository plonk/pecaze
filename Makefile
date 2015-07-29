.PHONY: clean

all: clock.rb

clean:
	rm -f clock.rb

clock.rb: custom_loop.rb clock_renderer.rb
	ruby rc.rb $< > clock.rb
