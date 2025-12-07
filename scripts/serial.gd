extends Node

var serial: GdSerial

func _ready():
	GlobalEvents.serial_message.connect(_on_serial_message)
	
	serial = GdSerial.new()
	
	# List available ports
	var ports = serial.list_ports()
	print("Available ports: ", ports)
	
	# Configure and connect
	serial.set_port("/dev/serial0")  # Adjust for your system
	serial.set_baud_rate(115200)
	serial.set_parity(false)
	serial.set_stop_bits(1)
	
	if serial.open():
		print("Serial connection open!")
		
func _process(delta):
	# Check if there is data waiting to be read
	if serial.bytes_available() > 0:
		# Read a single line from the serial buffer
		var input_line = serial.readline()
		
		if input_line:
			# Clean up the string (remove newline characters and leading/trailing spaces)
			var cleaned_input = input_line.strip_edges()
			print("Received: ", cleaned_input)
			
			# --- Game Logic Dispatch ---
			GlobalEvents.emit_signal("serial_data_received", cleaned_input)
		

func _on_serial_message(message):
	print(message)
	serial.writeline(message)
