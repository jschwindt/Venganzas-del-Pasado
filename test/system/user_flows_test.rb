require 'application_system_test_case'

class UserFlowsTest < ApplicationSystemTestCase
  test 'visiting home and register new user' do
    visit root_path
    assert_selector 'h2', text: 'Programas Recientes'

    click_on 'Registrate'
    assert_selector 'h3', text: 'Registrate en Venganzas del Pasado'

    fill_in 'Email', with: 'juan@example.com'
    fill_in 'Alias', with: 'juan'
    fill_in 'Contraseña', with: 'Password'
    fill_in 'Confirmación de contraseña', with: 'Password'

    click_on 'Crear Cuenta'
    assert_selector 'div', text: 'Se ha enviado un mensaje con un enlace de confirmación a tu dirección de mail. Por favor, hacé click en el enlace para confirmar tu cuenta.'
  end
end
