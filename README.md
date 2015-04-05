# PaymentSystem

Created for ECE 330

To get this up and running you need an initialization file. The initialization
file should contain your weekly and salary payment dates, as well as a payroll
clerk to start the program the first time.

This program is a demo only and does not save data. Don't actually use it.

If you are using with Rails, put this block in an initializer. Otherwise, put it
in the same file you execute, or one loaded from it.

Here is a sample configuration block (replace `paymentsystem` with the actual
folder you place these files in):

``` ruby
require 'paymentsystem/config'

PaymentSystem.configure do |config|
  config.hourly_day    = "Friday"
  config.salary_day    = 1
  config.payroll_clerk   "Ricardo", "password"
end
```

If you'd like to use my CLI, I recommend this first line to make it
shell executable:

``` bash
#!/usr/bin/env ruby
```

It needs these two requires to run on console (replace `paymentsystem` with the
folder you put these files in):
``` ruby
require 'io/console'
require 'paymentsystem/routine'
```

Then, put your configuration block. After that, start the program with `run`:

``` ruby
PaymentSystem.run
```

Hourly employees get overtime after 40 hours. Salary employees get no overtime.
This is for a class project so you'll probably encounter really weird bugs.

>> Ricardo
