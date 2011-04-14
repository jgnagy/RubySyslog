class CreateLogs < ActiveRecord::Migration
  def self.up
	create_table :logs do |t|
		t.string :hostname
		t.text :msg
		t.integer :facility
		t.integer :severity
		
		t.timestamps
	end
	
	add_index :logs, [:hostname, :facility, :severity]
  end
  
  def self.down
	drop_table :logs
  end
end