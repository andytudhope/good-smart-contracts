// A simplified list structure with the intended purpose of only
// storing a set of byte32 values in an arbitrary order.
// Some optimization included for position lookups
// Written by: Dennis Mckinnon 2016

contract serialize{

	struct serial_element {
		bytes32 prev;
		bytes32 next;
		bool exists;
	}

	struct serialList {
		bytes32 head;
		bytes32 tail;
		mapping (bytes32 => serial_element) elements;
		uint len;
	}

	function exists(serialList storage list, bytes32 value) internal returns (bool){
		return list.elements[value].exists;
	}

	function append(serialList storage list, bytes32 value) internal{
		//Inserts into the list if its not already there.
		if (list.elements[value].exists) return;

		list.elements[value].exists = true;
		//handle empty list condition
		if (list.len == 0) {
			list.head = value;
			list.tail = value;
		} else {
			list.elements[value].next = list.head;
			list.elements[list.head].prev = value;
			list.head = value;
		}

		list.len += 1;
	}

	function remove(serialList storage list, bytes32 value) internal{
		//Removes from the list if it exists.
		if (!list.elements[value].exists) return;

		// Check if we have a new head or tail
		if (list.head == value) {
			list.head = list.elements[value].next;
		}

		if (list.tail == value) {
			list.tail = list.elements[value].prev;
		}

		// Remove link
		list.elements[list.elements[value].next].prev = list.elements[value].prev;
		list.elements[list.elements[value].prev].next = list.elements[value].next;
		list.elements[value].prev = bytes32(0);
		list.elements[value].next = bytes32(0);
		list.elements[value].exists = false;

		list.len -= 1;
	}

	function getAtPos(serialList storage list, uint pos) internal returns (bytes32 value){
		//Loops through list to find value at position
		uint i;
		bytes32 current;
		if (pos <= list.len/2) {
			//Start counting from head
			current = list.head;
			for (i = 0; i < pos; i++) {
				current = list.elements[current].next;
			}
		} else if (pos > list.len/2 && pos < list.len) {
			//Start counting from tail
			current = list.tail;
			for (i = list.len-1; i < pos; i--){
				current = list.elements[current].prev;
			}
		}

		return current;
	}
}